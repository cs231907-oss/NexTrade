from django.contrib.auth.models import User
from django.db import models


# Create your models here.

#for customer
class Customer(models.Model):
    name=models.CharField(max_length=200)
    email=models.CharField(max_length=200)
    phone=models.CharField(max_length=10)
    photo=models.CharField(max_length=200)
    district=models.CharField(max_length=200)
    state=models.CharField(max_length=200)
    pin=models.CharField(max_length=10)
    status=models.CharField(max_length=10)
    USER=models.OneToOneField(User,on_delete=models.CASCADE)
#for news
class News(models.Model):
    title=models.CharField(max_length=200)
    description=models.CharField(max_length=1500)
    date=models.DateField()

#for video
class Videos(models.Model):
    video= models.CharField(max_length=200)
    title= models.CharField(max_length=200)
    date = models.DateField()

#for notify
class Notifications(models.Model):
    title= models.CharField(max_length=200)
    date= models.DateField()

#for complaint
class Complaint(models.Model):
    complaint= models.CharField(max_length=200)
    date= models.DateField()
    reply = models.CharField(max_length=200)
    status= models.CharField(max_length=15)
    CUSTOMER=models.ForeignKey(Customer,on_delete=models.CASCADE)

#for feedback
class Feedback(models.Model):
    feedback= models.CharField(max_length=200)
    date= models.DateField()
    CUSTOMER = models.ForeignKey(Customer, on_delete=models.CASCADE)

class favourite(models.Model):
    name=models.CharField(max_length=200)
    CUSTOMER = models.ForeignKey(Customer, on_delete=models.CASCADE)

class Buy_stock(models.Model):
    FAVOURITE=models.ForeignKey(favourite, on_delete=models.CASCADE)
    date = models.DateField(default="2025-11-22")
    stock=models.IntegerField() #stock quantity set to buy
    purchase_price=models.FloatField(default='0')
    total_amount = models.FloatField(default='0')  # stock_bought total amount
class Sell_stock(models.Model):
    BUYSTOCK=models.ForeignKey(Buy_stock, on_delete=models.CASCADE)
    date = models.DateField(default="2025-11-22")
    stock_quantity=models.IntegerField() #stock quantity set to sell
    sell_price = models.FloatField(default='0')
    total_amount=models.FloatField(default='0') #stock_sold total amount
class Wallet(models.Model):
    CUSTOMER = models.ForeignKey(Customer, on_delete=models.CASCADE)
    amount=models.IntegerField()
