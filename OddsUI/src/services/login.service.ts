import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { BehaviorSubject, Observable} from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class LoginService {

  loginUrl: string = 'http://localhost:8080/api/user/login';

  constructor(private http: HttpClient) { }

  attemptLogin(username: string, password: string): Observable<string> {
    const body = {"username": username, "pw": password};
    const headers = new HttpHeaders({
      'Content-Type': 'text/plain; charset=utf-8'
    });
    return this.http.post<string>(this.loginUrl, body, {responseType: 'text' as 'json'});
  }

  isLoggedIn(): boolean {
    return !!localStorage.getItem('login')
  }

}
