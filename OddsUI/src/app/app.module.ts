import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { HttpClientModule, HttpClient } from '@angular/common/http';
import { AppComponent } from './app.component';
import { CurrentBetsComponent } from './current-bets/current-bets.component';
import { CurrentBetsService } from 'src/services/current-bets.service';
import { LoginComponent } from './login/login.component';
import { LoginService } from 'src/services/login.service';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatInputModule } from '@angular/material/input';
import {MatDatepickerModule} from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSelectModule } from '@angular/material/select';
import { BookedBetService } from 'src/services/booked-bet.service';

@NgModule({
  declarations: [
    AppComponent,
    CurrentBetsComponent,
    LoginComponent,
    
  ],
  imports:[
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    MatInputModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatButtonModule,
    MatIconModule,
    MatSelectModule,

  ],
  providers: [
    CurrentBetsService,
    LoginService,
    BookedBetService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
