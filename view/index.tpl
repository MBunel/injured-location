<html>
  <head>
    <title>{{title}}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="static/leaflet.css"/>
    <script src="static/leaflet.js"></script>

    <script src="static/simpleheat.js"></script>
    <script src="static/HeatLayer.js"></script>

    <link rel="stylesheet" href="static/easy-button.css">
    <script src="static/easy-button.js"></script>

    <link rel="stylesheet" href="static/GpPluginLeaflet-src.css"/>
    <script src="static/GpPluginLeaflet-src.js"></script>


    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.3.1/css/all.css" integrity="sha384-mzrmE5qonljUremFsqc01SB46JvROS7bZs3IO2EmfFsd15uHvIt+Y8vEf7N7fWAU" crossorigin="anonymous">

    <style>
      html,body{
	  margin:0;
	  padding:0;
	  height:100%;
	  width:100%;
      }
      #map{
          height:100%;
          width:100%;
          overflow:hidden;
      }
      .easy-button-button .button-state {
        width: auto;
        height: auto;
    }
    </style>
  </head>
  <body>
    <div id="map">
    </div>
    <script>
      // Variables globables
      var userMarker = L.marker();
      var otherMarker = [];

      var heat = L.heatLayer();
      var defaultPosition = [45.054, 6.03];
      var map = L.map('map').setView(defaultPosition, 12);
      var scale = L.control.scale({imperial:false}).addTo(map);


      function addPoint(e){
          userMarker.setLatLng(e.latlng, {draggable: 'true'}).addTo(map);
      }

      function removePoints(){
    	  map.removeLayer(userMarker);
    	  userMarker = L.marker();

    	  for (var i = 0; i < otherMarker.length; i++) {
    	      map.removeLayer(otherMarker[i]);
    	    }
    	  otherMarker = [];
    	  heat.remove();

    	  map.setView(defaultPosition, 12);
      }


      function sendPoint(x, y){
	  var request = new XMLHttpRequest();
	  request.open('GET', '/sendPoint?x=' + x + '&y=' + y, true);
	  request.send();
      }

      function getPoints(from='2017-01-01') {
	  var request = new XMLHttpRequest();
	  request.open('GET', '/getPoints?from=' + from, true);

	  request.onreadystatechange = function() {
	      if (this.readyState == 4 && this.status == 200) {
		  var data = JSON.parse(request.response);

		  var points = [];

		  for (var i = 0; i < data.data.length; i++) {
		      points.push([data.data[i]['y'],data.data[i]['x'], 10]);
		  }

		  console.log(points);

		  heat.remove();
		  heat = L.heatLayer(points, {
		    //radius:5,
		    //gradient:{0.4: 'white', 0.65: 'grey', 1: 'blue'}
		    gradient: {0.4: '#49006a', 1: '#49006a'},
		    blur: 30,
		    minOpacity: 0.8
	      }).addTo(map);
	      }
	  }
	  request.send();
      }

      //Events
      map.on('click', addPoint);

      // Couches Géoportail
      function genMap() {

	  L.geoportalLayer.WMS({
	      layer: "ORTHOIMAGERY.ORTHOPHOTOS.BDORTHO",
	  }).addTo(map);

	  L.geoportalLayer.WMTS({
	      layer: "TRANSPORTNETWORKS.ROADS",
	  }).addTo(map);

	  L.geoportalLayer.WMTS({
	      layer: "UTILITYANDGOVERNMENTALSERVICES.ALL",
	  }).addTo(map);

	   L.geoportalLayer.WMTS({
	      layer: "HYDROGRAPHY.HYDROGRAPHY",
	  }).addTo(map);

      L.geoportalLayer.WMTS({
	      layer: "GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.CLASSIQUE",
	  }).addTo(map);

	  map.addControl(
	      L.geoportalControl.LayerSwitcher()
	  );



	  L.easyButton('fas fa-upload', function(){
	    var coords = userMarker.getLatLng()
    	  if (coords !== undefined){
    	  	getPoints();
    	    sendPoint(coords.lng, coords.lat);
    	  }
      }).addTo(map);

      L.easyButton('fas fa-redo', removePoints).addTo(map);
      }

      window.onload = function(){
	  Gp.Services.getConfig({
		  //apiKey: 'm826cbzfvny27ro0tl7xpxd6',
		  serverUrl: "/static/autoconf.json",
		  callbackSuffix : "",
	      onSuccess: genMap
	  });
      }


    </script>
  </body>
</html>
