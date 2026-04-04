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

  form!: FormGroup;
  loading = false;
  submitted = false;
  errorMessage = "";

  constructor(
    private loginService: LoginService, 
    private router: Router,
    private formBuilder: FormBuilder,
  ){}

  ngOnInit() {
        this.form = this.formBuilder.group({
            username: ['', Validators.required],
            password: ['', Validators.required]
        });
    }

  get f() { return this.form.controls; }

  onSubmit() {
    this.submitted = true;
    if(this.form.invalid){
      return;
    }
    this.loading = true;
    this.loginService.attemptLogin(this.f['username'].value, this.f['password'].value).subscribe({
      next: (response: string) =>{
        localStorage.setItem('login', response);
        this.router.navigate(['/home']);
      },
      error: (error: any) => {
        console.log(error)
        this.errorMessage = 'Invalid credentials.'
        this.loading = false;
      }
    });
  }


}
