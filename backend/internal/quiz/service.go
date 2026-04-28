package quiz

import (
	"errors"
	"math/rand"
	"nutribunda-backend/internal/database"
	"time"

	"gorm.io/gorm"
)

// Service handles quiz business logic
type Service struct {
	db *gorm.DB
}

// NewService creates a new quiz service
func NewService(db *gorm.DB) *Service {
	return &Service{
		db: db,
	}
}

// GetRandomQuestions returns random quiz questions
// Requirements: 10.2 - Select 10 random questions from available question pool
func (s *Service) GetRandomQuestions(limit int) ([]database.QuizQuestion, error) {
	if limit <= 0 {
		limit = 10 // Default to 10 questions as per requirement
	}

	var questions []database.QuizQuestion
	
	// Get total count of questions
	var totalCount int64
	if err := s.db.Model(&database.QuizQuestion{}).Count(&totalCount).Error; err != nil {
		return nil, err
	}

	if totalCount == 0 {
		return nil, errors.New("no quiz questions available")
	}

	// If we have fewer questions than requested, return all
	if int(totalCount) <= limit {
		if err := s.db.Find(&questions).Error; err != nil {
			return nil, err
		}
		return questions, nil
	}

	// Generate random offsets to get random questions
	// Requirements: 10.7 - Ensure question order different from previous session
	rand.Seed(time.Now().UnixNano())
	offsets := make(map[int]bool)
	
	// Generate unique random offsets
	for len(offsets) < limit {
		offset := rand.Intn(int(totalCount))
		offsets[offset] = true
	}

	// Fetch questions at random offsets
	for offset := range offsets {
		var question database.QuizQuestion
		if err := s.db.Offset(offset).Limit(1).Find(&question).Error; err != nil {
			return nil, err
		}
		questions = append(questions, question)
	}

	// Shuffle the questions array for additional randomization
	rand.Shuffle(len(questions), func(i, j int) {
		questions[i], questions[j] = questions[j], questions[i]
	})

	return questions, nil
}

// SubmitAnswers evaluates quiz answers and returns score
// Requirements: 10.3, 10.4 - Add 10 points for correct answers, show correct answer for wrong ones
func (s *Service) SubmitAnswers(answers []AnswerSubmission) (*QuizResult, error) {
	if len(answers) == 0 {
		return nil, errors.New("no answers provided")
	}

	result := &QuizResult{
		Score:       0,
		TotalPoints: len(answers) * 10, // 10 points per question
		Results:     make([]QuestionResult, 0, len(answers)),
	}

	for _, answer := range answers {
		var question database.QuizQuestion
		if err := s.db.First(&question, "id = ?", answer.QuestionID).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, errors.New("question not found: " + answer.QuestionID)
			}
			return nil, err
		}

		questionResult := QuestionResult{
			QuestionID:    answer.QuestionID,
			Question:      question.Question,
			UserAnswer:    answer.Answer,
			CorrectAnswer: question.CorrectAnswer,
			IsCorrect:     answer.Answer == question.CorrectAnswer,
			Explanation:   question.Explanation,
		}

		// Add 10 points for correct answer (Requirement 10.3)
		if questionResult.IsCorrect {
			result.Score += 10
		}

		result.Results = append(result.Results, questionResult)
	}

	return result, nil
}

// GetAllQuestions returns all available quiz questions (for admin/testing purposes)
func (s *Service) GetAllQuestions() ([]database.QuizQuestion, error) {
	var questions []database.QuizQuestion
	if err := s.db.Find(&questions).Error; err != nil {
		return nil, err
	}
	return questions, nil
}

// AnswerSubmission represents a user's answer to a question
type AnswerSubmission struct {
	QuestionID string `json:"question_id" binding:"required"`
	Answer     string `json:"answer" binding:"required,oneof=A B C D"`
}

// QuizResult represents the result of a quiz submission
type QuizResult struct {
	Score       int              `json:"score"`
	TotalPoints int              `json:"total_points"`
	Results     []QuestionResult `json:"results"`
}

// QuestionResult represents the result for a single question
type QuestionResult struct {
	QuestionID    string  `json:"question_id"`
	Question      string  `json:"question"`
	UserAnswer    string  `json:"user_answer"`
	CorrectAnswer string  `json:"correct_answer"`
	IsCorrect     bool    `json:"is_correct"`
	Explanation   *string `json:"explanation"`
}