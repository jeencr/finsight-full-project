
from django.contrib import admin
from django.urls import path, include

from myapp import views

urlpatterns = [
    path('login_page/',views.login_page),
    path("admin_home/", views.admin_home, name="admin_home"),
    path("ft_news_view/", views.ft_news_view, name="ft_news_view"),
    path("login_post/",views.loginpost),
    path("register/",views.register),
    path("register_post/",views.register_post),
    path("viewexpert/",views.view_expert),
    path("accept_expert/<id>",views.accept_expert),
    path("reject_expert/<id>",views.reject_expert),
    path("viewinvesters/",views.view_investers),
    path("viewfeedback/",views.view_feedback),
    path("viewcomplaints/",views.view_complaints),
    path("complaint_replay/<id>",views.complaint_replay),
    path("complaint_replay_post/",views.complaint_replay_post),
    path("notification/",views.notification),
    path("notification_post/",views.notification_post),
    path("view_notification/",views.view_notification),
    path("delete_notification/<id>",views.delete_notification),
    path("expert_home/",views.expert_home),
    # path("editprofile/",views.manageprofile),
    path("viewprofile/",views.viewprofile),
    # path("managetips/",views.managetips),
    # path("managetips/",views.managetips),
    path("add_capital/",views.add_capital),
    path("addcapital/",views.addcapital),
    path("assignuser/",views.assign_users),






]
