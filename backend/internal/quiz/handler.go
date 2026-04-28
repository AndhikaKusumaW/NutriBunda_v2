package quiz

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// Handler handles HTTP requests for quiz endpoints
type Handler struct {
	service *Service
}

// NewHandler creates a new quiz handler
func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// GetQuestions handles GET /api/quiz/questions
// Requirements: 10.1, 10.2 - Present multiple choice trivia questions, select 10 random questions
func (h *Handler) GetQuestions(c *gin.Context) {
	// Get limit from query parameter, default to 10
	limitStr := c.DefaultQuery("limit", "10")
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 {
		limit = 10
	}

	// Maximum limit of 20 questions to prevent abuse
	if limit > 20 {
		limit = 20
	}

	questions, err := h.service.GetRandomQuestions(limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to fetch quiz questions",
			"message": err.Error(),
		})
		return
	}

	// Transform questions to hide correct answers and explanations
	// Requirements: 10.1 - Present trivia questions without revealing answers
	questionResponses := make([]QuestionResponse, len(questions))
	for i, q := range questions {
		questionResponses[i] = QuestionResponse{
			ID:       q.ID.String(),
			Question: q.Question,
			Options: []string{
				q.OptionA,
				q.OptionB,
				q.OptionC,
				q.OptionD,
			},
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"questions": questionResponses,
		"total":     len(questionResponses),
	})
}

// SubmitAnswers handles POST /api/quiz/submit
// Requirements: 10.3, 10.4, 10.5 - Score answers, show correct answers with explanations
func (h *Handler) SubmitAnswers(c *gin.Context) {
	var request SubmitRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	if len(request.Answers) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "No answers provided",
			"message": "At least one answer is required",
		})
		return
	}

	result, err := h.service.SubmitAnswers(request.Answers)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to evaluate quiz answers",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, result)
}

// GetAllQuestions handles GET /api/quiz/questions/all (for admin/testing)
func (h *Handler) GetAllQuestions(c *gin.Context) {
	questions, err := h.service.GetAllQuestions()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to fetch all quiz questions",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"questions": questions,
		"total":     len(questions),
	})
}

// QuestionResponse represents a quiz question response (without correct answer)
type QuestionResponse struct {
	ID       string   `json:"id"`
	Question string   `json:"question"`
	Options  []string `json:"options"`
}

// SubmitRequest represents a quiz submission request
type SubmitRequest struct {
	Answers []AnswerSubmission `json:"answers" binding:"required,dive"`
}