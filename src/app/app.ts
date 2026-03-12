import { Component } from '@angular/core';
import { RegistrationComponent } from '../registration/registration'; 

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RegistrationComponent], 
  templateUrl: './app.html',
})
export class AppComponent {}