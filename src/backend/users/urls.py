from django.urls import path
from .views import SignupView, DRFSignupView  # Import your views

urlpatterns = [
    path("signup/", SignupView.as_view(), name="signup"),  # URL for SignupView
    path("drf-signup/", DRFSignupView.as_view(), name="drf_signup"),  # URL for DRFSignupView
]
