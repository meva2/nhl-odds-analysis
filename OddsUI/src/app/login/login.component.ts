import { Component, OnInit } from '@angular/core';
import { LoginService } from 'src/services/login.service';
import { Router } from '@angular/router';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';


@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit{

  loginForm!: FormGroup;
  regForm!: FormGroup;
  login: boolean = true;
  register: boolean = false;
  loading: boolean = false;
  submitted: boolean = false;
  errorMessage: string = "";
  successMessage: string = "";

  constructor(
    private loginService: LoginService, 
    private router: Router,
    private formBuilder: FormBuilder,
  ){}

  ngOnInit() {
        this.loginForm = this.formBuilder.group({
            username: ['', Validators.required],
            password: ['', Validators.required]
        });

        this.regForm = this.formBuilder.group({
            username: ['', Validators.required],
            password: ['', Validators.required],
            passwordRepeat: ['', Validators.required],
        });
    }

  get fl() { return this.loginForm.controls; }
  get fr() { return this.regForm.controls; }

  onLogin(): void {
    this.submitted = true;
    this.successMessage = "";
    if(this.loginForm.invalid){
      return;
    }
    this.loading = true;
    this.loginService.attemptLogin(this.fl['username'].value, this.fl['password'].value).subscribe({
      next: (response: string) =>{
        localStorage.setItem('login', response);
        this.router.navigate(['/home']);
      },
      error: (error: any) => {
        console.log(error)
        this.errorMessage = error['error'];
        console.log(this.errorMessage);
        this.loading = false;
      }
    });
  }

  onRegister(): void {
    this.submitted = true;
    this.errorMessage = "";
    if(this.regForm.invalid){
      return;
    }
    if(!(this.fr['password'].value === (this.fr['passwordRepeat'].value))){
      this.errorMessage = "Passwords must match.";
      return;
    }
    this.loading = true;
    this.loginService.registerUser(this.fr['username'].value, this.fr['password'].value).subscribe({
      next: (response: string) =>{
        this.successMessage = response;
        this.loading = false;
        this.onToggleLogin();
      },
      error: (error: any) => {
        console.log(error)
        this.errorMessage = error['error'];
        this.loading = false;
      }
    });

  }

  onToggleLogin() {
    this.submitted = false;
    this.errorMessage = "";
    this.login = !this.login;
    this.register = !this.register;
  }


}
