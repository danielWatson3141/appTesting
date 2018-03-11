/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  Text,
  StyleSheet
} from 'react-native';
import MapView from 'react-native-maps';
//import ClusteredMapView from 'react-native-maps-super-cluster';
import image from './images/flag-pink.png';

export default class App extends Component<{}> {
  render() {

    // const coordinates = [];

    // coordinates.push({
    //   key: 0,
    //   location: {
    //     longitude: -70.23,
    //     latitude: -33.23
    //   }
    // });

    // for(let i = 1; i<100; i++) {

    //   const location = {
    //     longitude: coordinates[i-1].location.longitude + (Math.random() * (i%2 === 0 ? -1 : 1)),
    //     latitude: coordinates[i-1].location.latitude + (Math.random() * (i%2 === 0 ? -1 : 1)),
    //   };

    //   coordinates.push({ key: i, location });

    // }

    return (
      <MapView
        // renderMarker={renderMarker}
        // initialRegion={{
        //   longitude: 151,
        //   latitude: -34,
        //   latitudeDelta: 0,
        //   longitudeDelta: 0,
        // }}
        region={getDelta(-34, 151, 20000000)}
        style={StyleSheet.absoluteFillObject}>

      </MapView>
    );
  }
}

function getDelta(lat, lon, distance): Coordinates {
   const oneDegreeOfLatitudeInMeters = 111.32 * 1600;

   const latitudeDelta =distance / oneDegreeOfLatitudeInMeters;
   const longitudeDelta = distance / (oneDegreeOfLatitudeInMeters * Math.cos(lat * (Math.PI / 180)));

   return result = {
       latitude: lat,
       longitude: lon,
       latitudeDelta,
       longitudeDelta,
   }
}

function renderMarker({ location }) {
  return (
    <MapView.Marker
      image={image}
      coordinate={location}
    >
      <MapView.Callout>
        <Text>BiG BiG Callout</Text>
      </MapView.Callout>
    </MapView.Marker>
  );
}
