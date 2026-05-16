"""tradinapp URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

from myapp import views

urlpatterns = [
    path('home_index/',views.h_index),
    path('login/',views.login_get),
    path('login_post/',views.login_post),
    path('changepswd_get/',views.changepswd),
    path('changepswd_post/',views.changepswd_post),
    path('forgot_password_get/', views.forgot_password),
    path('forgot_password_post/', views.forgotpassword_post),
    path('logout/',views.logout),
    path('add_video/',views.addvideo),
    path('add_video_post/',views.addvideo_post),
    path('edit_video/<id>', views.editvideo),
    path('editvideo_post/',views.editvideo_post),
    path('view_video/', views.viewvideo),
    path('deletevideo/<id>', views.deletevideo),
    path('add_news/', views.addnews),
    path('addnews_post/',views.addnews_post),
    path('edit_news/<id>', views.editnews),
    path('editnews_post/',views.editnews_post),
    path('deletenews/<id>',views.deletenews),
    path('view_news/',views.viewnews),
    path('add_notify/',views.addnotify),
    path('add_notifi_post/',views.addnotify_post),
    path('edit_notify/<id>',views.editnotify),
    path('edit_notifi_post/', views.editnotify_post),
    path('deletenotify/<id>',views.deletenotify),
    path('view_notify/', views.viewnotify),
    path('view_complaint/', views.viewcomplaint),
    path('send_reply/<id>', views.sendreply),
    path('send_reply_post/',views.sendreply_post),
    path('view_feed/', views.viewfeed),
    path('view_users/',views.viewusers),
    path('blocked/<id>', views.block_user),
    path('unblocked/<id>', views.unblock_user),

    #stock urls
    path('allstock/', views.getallstock),
    path('stock_details/', views.stock_detail),
    path('priceprediction/', views. priceprediction),
    # user url
    path('ulogin/',views.user_login),
    path('usignup/',views.user_signup),
    path('user_changepassword/',views.user_changepassword),
    path('user_editprofile/',views.user_editprofile),
    path('user_viewprofile/',views.user_viewprofile),
    path('user_viewvideos/',views.user_viewvideos),
    path('user_viewnews/',views.user_viewnews),
    path('user_viewnotification/', views.user_viewnotification),
    path('user_sendfeedback/',views.user_sendfeedback),
    path('user_sendcompliant/',views.user_sendcompliant),
    path('user_viewreply/', views.user_viewreply),
    path('favstock/',views.addfav_post),
    path('viewfav_stocks/',views.viewFav),
    path('remove_fav_stock/',views.remove_fav_stock),
    path('buy_stock/',views.buy_stock),
    path('view_buy_stock/',views.view_buy_stock),
    path('sell_stock/', views.sell_stock),
    path('view_sell_stock/', views.view_sell_stock),
    path('view_sell_fastock/', views.view_sell_fastock),
    path('buy_high_graph/', views.buy_high_graph),
    path('Recharge_coin/', views.Recharge_coin),
    path('Balance_coin/', views.Balance_coin),
    path('android_forget_password_post/', views.android_forget_password_post),
]
