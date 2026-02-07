from django.db import models
from django.contrib.auth.models import User

# Create your models here.
from django.db.models import Model


class Expert(models.Model):
    LOGIN=models.OneToOneField(User,on_delete=models.CASCADE)
    name=models.CharField(max_length=50)
    specilization=models.CharField(max_length=100)
    photo=models.ImageField(upload_to='expert_photo')
    experiance=models.CharField(max_length=10)
    status=models.CharField(max_length=100)
    phone=models.CharField(max_length=15)
    email=models.CharField(max_length=50)

class Investers (models.Model):
    LOGIN=models.OneToOneField(User,on_delete=models.CASCADE)
    name=models.CharField(max_length=50)
    place=models.CharField(max_length=100)
    photo=models.ImageField(upload_to='invester_photo')
    age=models.CharField(max_length=5)
    phone=models.CharField(max_length=15)
    nationality=models.CharField(max_length=100)
    email=models.CharField(max_length=50)

class Forex_predection(models.Model):
        EXPERT = models.ForeignKey(Expert, on_delete=models.CASCADE)
        currency = models.CharField(max_length=50)
        result= models.TextField()
        date= models.DateField ()

class Feed_back (models.Model):
    Expert=models.ForeignKey(Expert, on_delete=models.CASCADE)
    Investers=models.ForeignKey (Investers, on_delete=models.CASCADE)
    feedback=models.CharField(max_length=500)
    date=models.DateField()


class Complaints(models.Model):
    Investers=models.ForeignKey(Investers, on_delete=models.CASCADE)
    conplaint=models.CharField(max_length=100)
    replay=models.CharField(max_length=100)
    date = models.DateField()


class UserPortfolio(models.Model):
    Expert=models.ForeignKey(Expert, on_delete=models.CASCADE)
    Investers=models.ForeignKey(Investers, on_delete=models.CASCADE)
    company=models.CharField(max_length=100)
    date = models.CharField(max_length=100)
    price_per_stock_when_bought = models.CharField(max_length=100)
    number_of_stocks = models.CharField(max_length=100)

class Notification(models.Model):
    title = models.CharField(max_length=100)
    description = models.CharField(max_length=100)
    date = models.DateField()


class Tips(models.Model):
    Expert= models.ForeignKey(Expert, on_delete=models.CASCADE)
    company = models.CharField(max_length=100)
    sector = models.CharField(max_length=100)
    recommendation = models.CharField(max_length=100)
    tips = models.CharField(max_length=100)
    description = models.CharField(max_length=100)

class Investment(models.Model):
    company = models.CharField(max_length=100)
    company_info = models.TextField()
    current_price= models.CharField(max_length=100)
    high_low= models.CharField(max_length=100)

class User_request(models.Model):
    Investers = models.ForeignKey(Investers, on_delete=models.CASCADE)
    amount=models.CharField(max_length=50)
    income=models.CharField(max_length=50)
    occupation=models.CharField(max_length=100)
    status=models.CharField(max_length=100,default='pending')
    Expert = models.ForeignKey(Expert,on_delete=models.CASCADE)

class Assgin_expert(models.Model):
    Expert=models.ForeignKey(Expert, on_delete=models.CASCADE)
    Investers=models.ForeignKey(Investers, on_delete=models.CASCADE)

class Chat(models.Model):
    from_id=models.ForeignKey(User, on_delete=models.CASCADE, related_name='from_id')
    to_id=models.ForeignKey(User, on_delete=models.CASCADE, related_name='to_id')
    message=models.CharField(max_length=1000)
    date = models.DateTimeField()

class Capital(models.Model):
    requierd_capital=models.CharField(max_length=50)
    Expert = models.ForeignKey(Expert, on_delete=models.CASCADE)
    returns=models.CharField(max_length=1000)









