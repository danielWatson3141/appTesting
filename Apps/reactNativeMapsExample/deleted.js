{ coordinates.map(({ key, location } ) => <MapView.Marker key={key} image={image} coordinate={location} />) }