import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable} from 'rxjs';


export interface CurrentBet{
  startTimeUTC: Date;
  homeTeam: string;
  awayTeam: string;
  total: number;
  overPrice: number;
  underPrice: number;
  overPriority: number;
  underPriority: number;
}

@Injectable({
  providedIn: 'root'
})
export class CurrentBetsService {

  currentBetsUrl: string = 'http://localhost:8080/api/currentBets'

  constructor(private http: HttpClient) { }

  getCurrentBets(): Observable<CurrentBet[]> {
    return this.http.get<any>(this.currentBetsUrl)
  }
}
