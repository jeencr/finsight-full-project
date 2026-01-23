from datetime import datetime
from django.contrib import messages
from django.contrib.auth import authenticate, login
from django.http import request
from django.shortcuts import render, redirect
from django.contrib.auth.models import User, Group

# Create your views here.
from myapp.models import *
from myapp.utils import scrape_ft


def login_page(request):
    return render(request, 'loginpage.html')


def ft_news_view(request):
    include_html = request.GET.get("html") == "1"
    articles = scrape_ft(include_html=include_html)
    return render(request, "ft_table.html", {"articles": articles})

def admin_home(request):
    return render(request,'admin/adminhome.html')

def loginpost(request):
    username = request.POST['email']
    password = request.POST['password']
    print(username,password)

    user = authenticate(request, username=username, password=password)
    if user is not None:
        if user.groups.filter(name="admin").exists():
            print("admin")
            login(request, user)
            return redirect('/myapp/admin_home')

        elif user.groups.filter(name='expert').exists():
            expert=Expert.objects.get(LOGIN=user)
            if expert.status=='accepted':

                print("expert")
                login(request,user)
                return redirect('/myapp/expert_home/')
            else :
                messages.warning(request,'user rejected')
                return redirect('/myapp/login_page')

        else:
            messages.warning(request, "invalid user")

            return redirect('/myapp/login_page')
    else:
        messages.warning(request, "invalid usename or password")
        return redirect('/myapp/login_page/')

def register(request):
    return render (request,"signup.html")

def register_post(request):
    specilization = request.POST['specilization']
    name = request.POST['name']
    photo = request.FILES['photo']
    experiance = request.POST['experiance']
    phone = request.POST['phone']
    email = request.POST['email']
    username = request.POST['username']
    password = request.POST['password']

    if User.objects.filter(username=username).exists():
        messages.warning(request, "user already exist")
        return redirect('/myapp/register/')
    else:
        user=User.objects.create_user(username=username,password=password)
        user.groups.add(Group.objects.get(name='expert'))
        expert=Expert()
        expert.name = name
        expert.specilization= specilization
        expert.photo= photo
        expert.experiance=experiance
        expert.phone=phone
        expert.email=email
        expert.status='pending'
        expert.LOGIN=user
        expert.save()
        return redirect('/myapp/login_page/')

def view_expert(request):
    experts=Expert.objects.all()
    return render(request,'admin/viewexpert.html',{"experts":experts})


def accept_expert(request,id):
    accept=Expert.objects.get(id=id)
    accept.status='accepted'
    accept.save()
    messages.success(request,'this expert accepted')
    return redirect('/myapp/viewexpert/')


def reject_expert(request,id):
    reject=Expert.objects.get(id=id)
    reject.status='rejected'
    reject.save()
    messages.success(request,'this expert rejected')
    return redirect('/myapp/viewexpert/')

def view_investers(request):
    investers=Investers.objects.all()
    return render(request,'admin/viewinvesters.html',{"investers":investers})


def view_feedback(request):
    viewfeedback=Feed_back.objects.all()
    return render(request,'admin/viewfeedback.html',{"viewfeedback":viewfeedback})


def view_complaints(request):
    viewcomplaints=Complaints.objects.all()
    return render(request,'admin/complaint.html',{"viewcomplaints":viewcomplaints})


def complaint_replay(request,id):
    viewcomplaints=Complaints.objects.all()
    comp=Complaints.objects.get(id=id)

    return render(request,'admin/complaint.html',{"complaintreplay":comp,"viewcomplaints":viewcomplaints})


def complaint_replay_post(request):
    if request.POST:
        comp_id = request.POST['comp_id']
        print(comp_id)
        comp = Complaints.objects.get(id=comp_id)
        print(comp)
        reply = request.POST['reply']
        print(request.POST['reply'])
        comp.replay = reply
        comp.save()
        return redirect('/myapp/viewcomplaints/')

def notification(request):
        return render(request, 'admin/notification.html' )

def notification_post(request):
    if request.POST:
        title=request.POST['title']
        description=request.POST['discription']
        comp = Notification()
        comp.title=title
        comp.description=description
        comp.date=datetime.now()
        comp.save()
        return redirect('/myapp/notification/')




def view_notification(request):
    viewnotification=Notification.objects.all()
    return render(request,'admin/viewnotification.html',{"viewnotification":viewnotification})

def delete_notification(request,id):
    deletenotification=Notification.objects.get(id=id)
    deletenotification.delete()
    return redirect('/myapp/view_notification/')

def expert_home(request):
    return render(request,'expert/expertheader.html')


def viewprofile(request):
    expertid=request.user.id
    viewprofile=Expert.objects.get(LOGIN_id=expertid)
    return render(request,'expert/manageprofile.html',{"viewprofile":viewprofile})


def addcapital(request):
        return render(request, 'expert/add_capital.html' )

def add_capital(request):
    if request.POST:
        capital=request.POST['requierd_capital']
        returns=request.POST['returns']
        expertid = request.user.id
        id=Expert.objects.get(LOGIN_id=expertid)
        comp = Capital()
        comp.requierd_capital=capital
        comp.returns=returns
        comp.Expert=id
        comp.save()
    return redirect('/myapp/addcapital/')

def assign_users(request):
    id=request.user.id
    expertid = Expert.objects.get(LOGIN_id=id)
    assignuser = Assgin_expert.objects.filter(Expert=expertid)
    return render(request, 'expert/assignuser.html', {"assign_user": assignuser})




        #
# def managetips(request):
#     investers=Investers.objects.all()
#     return render(request,'admin/viewinvesters.html',{"investers":investers})