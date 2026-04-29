# Script untuk mengorganisir dokumentasi NutriBunda
# Memindahkan file .md ke struktur folder docs yang terorganisir

Write-Host "Starting documentation organization..." -ForegroundColor Green

# Backend Documentation
Write-Host "`nOrganizing Backend Documentation..." -ForegroundColor Yellow
Copy-Item "backend/API_TESTING_GUIDE.md" "docs/backend/api-testing-guide.md" -Force
Copy-Item "backend/README_TESTING.md" "docs/backend/testing-guide.md" -Force

# Backend Modules
Copy-Item "backend/internal/auth/README.md" "docs/backend/modules/auth.md" -Force
Copy-Item "backend/internal/user/README.md" "docs/backend/modules/user.md" -Force
Copy-Item "backend/internal/recipe/README.md" "docs/backend/modules/recipe/README.md" -Force
Copy-Item "backend/internal/recipe/TESTING.md" "docs/backend/modules/recipe/testing.md" -Force

# Backend Diary Module
Copy-Item "backend/internal/diary/README.md" "docs/backend/modules/diary/README.md" -Force
Copy-Item "backend/internal/diary/SYNC_API.md" "docs/backend/modules/diary/sync-api.md" -Force
Copy-Item "backend/internal/diary/SYNC_IMPLEMENTATION_SUMMARY.md" "docs/backend/modules/diary/sync-implementation.md" -Force
Copy-Item "backend/internal/diary/PROPERTY_TESTING_README.md" "docs/backend/modules/diary/property-testing.md" -Force
Copy-Item "backend/internal/diary/PROPERTY_TEST_SUMMARY.md" "docs/backend/modules/diary/property-test-summary.md" -Force

# Frontend Documentation
Write-Host "`nOrganizing Frontend Documentation..." -ForegroundColor Yellow
Copy-Item "nutribunda/README_TESTING.md" "docs/frontend/testing-guide.md" -Force
Copy-Item "nutribunda/ACCESSIBILITY_GUIDE.md" "docs/frontend/accessibility-guide.md" -Force
Copy-Item "nutribunda/PERFORMANCE_MONITORING_GUIDE.md" "docs/frontend/performance-monitoring.md" -Force

# Frontend Features
Copy-Item "nutribunda/lib/presentation/pages/auth/README.md" "docs/frontend/features/auth.md" -Force
Copy-Item "nutribunda/DIARY_INTEGRATION_GUIDE.md" "docs/frontend/features/diary-integration.md" -Force
Copy-Item "nutribunda/lib/presentation/pages/lbs/README.md" "docs/frontend/features/lbs.md" -Force
Copy-Item "nutribunda/lib/core/services/CHAT_SERVICE_README.md" "docs/frontend/features/chat-service.md" -Force
Copy-Item "nutribunda/lib/core/services/SYNC_SERVICE_README.md" "docs/frontend/features/sync-service.md" -Force

# Frontend Architecture
Copy-Item "nutribunda/lib/core/services/README.md" "docs/frontend/architecture/services.md" -Force
Copy-Item "nutribunda/lib/data/datasources/local/README.md" "docs/frontend/architecture/datasources.md" -Force
Copy-Item "nutribunda/lib/presentation/providers/README.md" "docs/frontend/architecture/providers/README.md" -Force
Copy-Item "nutribunda/lib/presentation/providers/diet_plan_provider_README.md" "docs/frontend/architecture/providers/diet-plan-provider.md" -Force

# Implementation Guides
Write-Host "`nOrganizing Implementation Guides..." -ForegroundColor Yellow
Copy-Item "nutribunda/GEMINI_API_SETUP_GUIDE.md" "docs/implementation/gemini-api-setup.md" -Force
Copy-Item "nutribunda/SQLITE_IMPLEMENTATION_SUMMARY.md" "docs/implementation/sqlite-implementation.md" -Force
Copy-Item "nutribunda/SYNC_IMPLEMENTATION_SUMMARY.md" "docs/implementation/sync-implementation.md" -Force
Copy-Item "nutribunda/NULL_SAFETY_FIX.md" "docs/implementation/null-safety-fix.md" -Force
Copy-Item "nutribunda/IMPLEMENTATION_NOTES.md" "docs/implementation/implementation-notes.md" -Force

# Pedometer Implementation
Copy-Item "nutribunda/PEDOMETER_UI_IMPLEMENTATION.md" "docs/implementation/pedometer/ui-implementation.md" -Force
Copy-Item "nutribunda/PEDOMETER_LOCATION.md" "docs/implementation/pedometer/location.md" -Force
Copy-Item "nutribunda/PEDOMETER_ERROR_FIX.md" "docs/implementation/pedometer/error-fix.md" -Force

# Task Summaries
Write-Host "`nOrganizing Task Summaries..." -ForegroundColor Yellow

# Task 6
Copy-Item "nutribunda/TASK_6.1_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-6/task-6.1-auth-provider.md" -Force
Copy-Item "nutribunda/TASK_6.2_BIOMETRIC_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-6/task-6.2-biometric.md" -Force
Copy-Item "nutribunda/TASK_6.3_SUMMARY.md" "docs/tasks/task-6/task-6.3-unit-tests.md" -Force

# Task 7
Copy-Item "nutribunda/TASK_7.1_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-7/task-7.1-diary-provider.md" -Force
Copy-Item "nutribunda/TASK_7.2_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-7/task-7.2-diary-ui.md" -Force
Copy-Item "nutribunda/TASK_7.3_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-7/task-7.3-unit-tests.md" -Force

# Task 8
Copy-Item "nutribunda/TASK_8.1_DIET_PLAN_PROVIDER_SUMMARY.md" "docs/tasks/task-8/task-8.1-diet-plan-provider.md" -Force
Copy-Item "nutribunda/TASK_8.2_DIET_PLAN_UI_SUMMARY.md" "docs/tasks/task-8/task-8.2-diet-plan-ui.md" -Force
Copy-Item "nutribunda/TASK_8.3_PROPERTY_TEST_SUMMARY.md" "docs/tasks/task-8/task-8.3-property-tests.md" -Force

# Task 10
Copy-Item "nutribunda/TASK_10.1_PEDOMETER_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-10/task-10.1-pedometer.md" -Force
Copy-Item "nutribunda/TASK_10.2_ACCELEROMETER_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-10/task-10.2-accelerometer.md" -Force
Copy-Item "nutribunda/TASK_10.3_ACCELEROMETER_PROPERTY_TEST_SUMMARY.md" "docs/tasks/task-10/task-10.3-property-tests.md" -Force

# Task 11
Copy-Item "nutribunda/TASK_11.1_RECIPE_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-11/task-11.1-recipe-provider.md" -Force
Copy-Item "nutribunda/TASK_11.2_FAVORITES_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-11/task-11.2-favorites.md" -Force
Copy-Item "nutribunda/TASK_11.3_RECIPE_UNIT_TESTS_SUMMARY.md" "docs/tasks/task-11/task-11.3-unit-tests.md" -Force

# Task 12
Copy-Item "nutribunda/TASK_12.1_LBS_SETUP_SUMMARY.md" "docs/tasks/task-12/task-12.1-lbs-setup.md" -Force
Copy-Item "nutribunda/TASK_12.2_LBS_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-12/task-12.2-lbs-implementation.md" -Force
Copy-Item "nutribunda/TASK_12.3_LBS_INTEGRATION_TESTS_SUMMARY.md" "docs/tasks/task-12/task-12.3-integration-tests.md" -Force

# Task 13
Copy-Item "nutribunda/TASK_13.1_GEMINI_API_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-13/task-13.1-gemini-api.md" -Force
Copy-Item "nutribunda/TASK_13.1_CHAT_UI_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-13/task-13.1-chat-ui-v1.md" -Force
Copy-Item "nutribunda/TASK_13.2_CHAT_UI_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-13/task-13.2-chat-ui-v2.md" -Force
Copy-Item "nutribunda/TASK_13.3_CHATBOT_UNIT_TESTS_SUMMARY.md" "docs/tasks/task-13/task-13.3-unit-tests.md" -Force

# Task 14
Copy-Item "nutribunda/TASK_14.1_QUIZ_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-14/task-14.1-quiz.md" -Force
Copy-Item "nutribunda/TASK_14.2_NOTIFICATION_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-14/task-14.2-notifications.md" -Force

# Task 15
Copy-Item "nutribunda/TASK_15.1_NAVIGATION_IMPLEMENTATION_SUMMARY.md" "docs/tasks/task-15/task-15.1-navigation.md" -Force

# Task 19
Copy-Item "nutribunda/TASK_19.1_UI_UX_ACCESSIBILITY_SUMMARY.md" "docs/tasks/task-19/task-19.1-accessibility.md" -Force

# Testing Documentation
Write-Host "`nOrganizing Testing Documentation..." -ForegroundColor Yellow
Copy-Item "nutribunda/test/README.md" "docs/testing/frontend/README.md" -Force
Copy-Item "nutribunda/test/QUIZ_NOTIFICATION_TESTS_SUMMARY.md" "docs/testing/frontend/quiz-notification-tests.md" -Force
Copy-Item "nutribunda/test/UI_NAVIGATION_TESTS_SUMMARY.md" "docs/testing/frontend/ui-navigation-tests.md" -Force

Write-Host "`n✅ Documentation organization complete!" -ForegroundColor Green
Write-Host "All documentation files have been copied to docs/ folder" -ForegroundColor Cyan
