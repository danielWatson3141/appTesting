import { Component, ViewChild, ElementRef } from '@angular/core';
import { IonicPage, NavController } from 'ionic-angular';

/**
 * Generated class for the MapsPage page.
 *
 * See https://ionicframework.com/docs/components/#navigation for more info on
 * Ionic pages and navigation.
 */

declare var google;

@IonicPage()
@Component({
  selector: 'page-maps',
  templateUrl: 'maps.html',
})
export class MapsPage {

  @ViewChild('map') mapElement: ElementRef;
  map: any;

  constructor(public navCtrl: NavController) {

	}

	ionViewDidLoad(){
	  this.initMap();
	}

	initMap() {
	  this.map = new google.maps.Map(this.mapElement.nativeElement, {
	    zoom: 2,
	    center: {lat: 34, lng: 151},
	    streetViewControl: false,
	    mapTypeControl: false,
	    fullscreenControl: false
	  });
	}

}
