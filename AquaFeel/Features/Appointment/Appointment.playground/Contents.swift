import Foundation
let apiKey = APIKeys.googleApiKey
func searchPlaces(searchText: String) {
    guard let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        print("Error")
        return
    }
    
    let origen = "6632 Alderbrook Dr, Denton, TX 76210, EE. UU."
    let destino = "Walmart Neighborhood Market, 3930 Teasley Ln, Denton, TX 76210, Estados Unidos"
    
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origen)&destination=\(destino)&key=\(apiKey)"
    
    if let url = URL(string: urlString) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
               
                 if let resultString = String(data: data, encoding: .utf8) {
                     print(resultString)
                 }
                 
               
            } else if let error = error {
                print("Error in request: \(error.localizedDescription)")
            }
        }.resume()
    }
}

func getPlaceDetails(placeID: String) {
    let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&key=\(apiKey)"
    
    if let url = URL(string: urlString) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(PlaceDetailsResult.self, from: data)
                    DispatchQueue.main.async {
                        print(result.result)
                    }
                } catch {
                    print("Error decoding: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("Error in request: \(error.localizedDescription)")
            }
        }.resume()
    }
}


searchPlaces(searchText: "6632 alder")


struct GoogleMapsResponse: Codable {
    let geocodedWaypoints: [GeocodedWaypoint]
    let routes: [Route]
    let status: String
}

struct GeocodedWaypoint: Codable {
    let geocoderStatus: String
    let placeID: String
    let types: [String]
}

struct Route: Codable {
    let bounds: Bounds
    let legs: [Leg]
    let overviewPolyline: OverviewPolyline
    let summary: String
    // Otros campos que necesites
}

struct Bounds: Codable {
    let northeast: Coordinate
    let southwest: Coordinate
}

struct Coordinate: Codable {
    let lat: Double
    let lng: Double
}

struct Leg: Codable {
    let distance: Distance
    let duration: Duration
    let endAddress: String
    let endLocation: Coordinate
    let startAddress: String
    let startLocation: Coordinate
    let steps: [Step]
}

struct Distance: Codable {
    let text: String
    let value: Int
}

struct Duration: Codable {
    let text: String
    let value: Int
}

struct Step: Codable {
    let distance: Distance
    let duration: Duration
    let endLocation: Coordinate
    let htmlInstructions: String
    let maneuver: String?
    let polyline: Polyline
    let startLocation: Coordinate
    let travelMode: String
}

struct Polyline: Codable {
    let points: String
}

struct OverviewPolyline: Codable {
    let points: String
}

// Decodifica el JSON
do {
    let jsonData = """
        {
    "geocoded_waypoints" :
    [
      {
         "geocoder_status" : "OK",
         "place_id" : "ChIJC1dpU1TLTYYRf1-5q9UnJIo",
         "types" :
         [
            "premise"
         ]
      },
      {
         "geocoder_status" : "OK",
         "partial_match" : true,
         "place_id" : "ChIJOcvbSkTLTYYRGcvv45G3bs4",
         "types" :
         [
            "bakery",
            "department_store",
            "establishment",
            "food",
            "grocery_or_supermarket",
            "point_of_interest",
            "store",
            "supermarket"
         ]
      }
    ],
    "routes" :
    [
      {
         "bounds" :
         {
            "northeast" :
            {
               "lat" : 33.1616854,
               "lng" : -97.0931578
            },
            "southwest" :
            {
               "lat" : 33.1494881,
               "lng" : -97.10778470000001
            }
         },
         "copyrights" : "Map data ©2024",
         "legs" :
         [
            {
               "distance" :
               {
                  "text" : "1.9 mi",
                  "value" : 3098
               },
               "duration" :
               {
                  "text" : "6 mins",
                  "value" : 384
               },
               "end_address" : "3930 Teasley Ln, Denton, TX 76210, USA",
               "end_location" :
               {
                  "lat" : 33.1600139,
                  "lng" : -97.1072368
               },
               "start_address" : "6632 Alderbrook Dr, Denton, TX 76210, USA",
               "start_location" :
               {
                  "lat" : 33.1494881,
                  "lng" : -97.095693
               },
               "steps" :
               [
                  {
                     "distance" :
                     {
                        "text" : "0.1 mi",
                        "value" : 174
                     },
                     "duration" :
                     {
                        "text" : "1 min",
                        "value" : 20
                     },
                     "end_location" :
                     {
                        "lat" : 33.1510323,
                        "lng" : -97.09571889999999
                     },
                     "html_instructions" : "Head \u003cb\u003enorth\u003c/b\u003e on \u003cb\u003eAlderbrook Dr\u003c/b\u003e towards \u003cb\u003ePine Hills Ln\u003c/b\u003e",
                     "polyline" :
                     {
                        "points" : "ioiiE`_soQMA}@Oy@CO?c@?E?q@HaAP"
                     },
                     "start_location" :
                     {
                        "lat" : 33.1494881,
                        "lng" : -97.095693
                     },
                     "travel_mode" : "DRIVING"
                  },
                  {
                     "distance" :
                     {
                        "text" : "492 ft",
                        "value" : 150
                     },
                     "duration" :
                     {
                        "text" : "1 min",
                        "value" : 21
                     },
                     "end_location" :
                     {
                        "lat" : 33.1508639,
                        "lng" : -97.0973068
                     },
                     "html_instructions" : "Turn \u003cb\u003eleft\u003c/b\u003e at the 1st cross street onto \u003cb\u003ePine Hills Ln\u003c/b\u003e",
                     "maneuver" : "turn-left",
                     "polyline" :
                     {
                        "points" : "}xiiEf_soQLbABLD`@Hz@@f@?v@Al@"
                     },
                     "start_location" :
                     {
                        "lat" : 33.1510323,
                        "lng" : -97.09571889999999
                     },
                     "travel_mode" : "DRIVING"
                  },
                  {
                     "distance" :
                     {
                        "text" : "0.6 mi",
                        "value" : 921
                     },
                     "duration" :
                     {
                        "text" : "1 min",
                        "value" : 55
                     },
                     "end_location" :
                     {
                        "lat" : 33.1581661,
                        "lng" : -97.0931647
                     },
                     "html_instructions" : "Turn \u003cb\u003eright\u003c/b\u003e onto \u003cb\u003eBarrel Strap Rd\u003c/b\u003e",
                     "maneuver" : "turn-right",
                     "polyline" :
                     {
                        "points" : "{wiiEdisoQWGmAa@MEoAy@sAqAw@s@yBsBAAo@i@g@a@[Ya@[sA_Aa@U_@UMIgEaCuBs@ICgASo@Im@EgCAy@?"
                     },
                     "start_location" :
                     {
                        "lat" : 33.1508639,
                        "lng" : -97.0973068
                     },
                     "travel_mode" : "DRIVING"
                  },
                  {
                     "distance" :
                     {
                        "text" : "0.7 mi",
                        "value" : 1160
                     },
                     "duration" :
                     {
                        "text" : "2 mins",
                        "value" : 104
                     },
                     "end_location" :
                     {
                        "lat" : 33.1584174,
                        "lng" : -97.1054625
                     },
                     "html_instructions" : "Turn \u003cb\u003eleft\u003c/b\u003e onto \u003cb\u003eRobinson Rd\u003c/b\u003e",
                     "maneuver" : "turn-left",
                     "polyline" :
                     {
                        "points" : "qekiEforoQU@?h@CjDAhAArAL^D`A@D@^?|@?BAt@AhAC~BAdBAjDAj@?h@A`BAlA?r@C`D?FAlA?F?lA?FCxBAv@AxBA\\?nBAzACbA?LCpA"
                     },
                     "start_location" :
                     {
                        "lat" : 33.1581661,
                        "lng" : -97.0931647
                     },
                     "travel_mode" : "DRIVING"
                  },
                  {
                     "distance" :
                     {
                        "text" : "0.2 mi",
                        "value" : 391
                     },
                     "duration" :
                     {
                        "text" : "1 min",
                        "value" : 38
                     },
                     "end_location" :
                     {
                        "lat" : 33.1616854,
                        "lng" : -97.10659729999999
                     },
                     "html_instructions" : "Turn \u003cb\u003eright\u003c/b\u003e onto \u003cb\u003eTeasley Ln\u003c/b\u003e",
                     "maneuver" : "turn-right",
                     "polyline" :
                     {
                        "points" : "cgkiEb|toQELAHsADmABC?u@?k@B[@UDa@HQDSDUFUHSHg@R]POHIDc@Z_@V_@X"
                     },
                     "start_location" :
                     {
                        "lat" : 33.1584174,
                        "lng" : -97.1054625
                     },
                     "travel_mode" : "DRIVING"
                  },
                  {
                     "distance" :
                     {
                        "text" : "377 ft",
                        "value" : 115
                     },
                     "duration" :
                     {
                        "text" : "1 min",
                        "value" : 19
                     },
                     "end_location" :
                     {
                        "lat" : 33.1615388,
                        "lng" : -97.10778470000001
                     },
                     "html_instructions" : "Turn \u003cb\u003eleft\u003c/b\u003e onto \u003cb\u003eE Ryan Rd\u003c/b\u003e",
                     "maneuver" : "turn-left",
                     "polyline" :
                     {
                        "points" : "q{kiEfcuoQHNPd@@R@L?NAbC"
                     },
                     "start_location" :
                     {
                        "lat" : 33.1616854,
                        "lng" : -97.10659729999999
                     },
                     "travel_mode" : "DRIVING"
                  },
                  {
                     "distance" :
                     {
                        "text" : "0.1 mi",
                        "value" : 187
                     },
                     "duration" :
                     {
                        "text" : "2 mins",
                        "value" : 127
                     },
                     "end_location" :
                     {
                        "lat" : 33.1600139,
                        "lng" : -97.1072368
                     },
                     "html_instructions" : "Turn \u003cb\u003eleft\u003c/b\u003e\u003cdiv style=\"font-size:0.9em\"\u003eDestination will be on the right\u003c/div\u003e",
                     "maneuver" : "turn-left",
                     "polyline" :
                     {
                        "points" : "szkiErjuoQb@Ap@A|@?F?L?JALCB?JAFE@APK@ATYJMJMPS"
                     },
                     "start_location" :
                     {
                        "lat" : 33.1615388,
                        "lng" : -97.10778470000001
                     },
                     "travel_mode" : "DRIVING"
                  }
               ],
               "traffic_speed_entry" : [],
               "via_waypoint" : []
            }
         ],
         "overview_polyline" :
         {
            "points" : "ioiiE`_soQkAQiACi@?sBZ`@nD@~AAl@WG{Ag@oAy@sAqAqDgDq@k@cA{@uB{AwGwD_Cw@wB]uDGoA@GrJL^D`ABd@C`EI|LIlOKjRCpACpAELAHsADqABaBBq@F}A\\i@ReAd@}AbA_@XHNPd@@R@\\AbCb@AnBAT?h@G\\U~@iA"
         },
         "summary" : "Barrel Strap Rd/FM 2499 and Robinson Rd",
         "warnings" : [],
         "waypoint_order" : []
      }
    ],
    "status" : "OK"
    }
    """.data(using: .utf8)!
    
    let decoder = JSONDecoder()
    let googleMapsResponse = try decoder.decode(GoogleMapsResponse.self, from: jsonData)
    
    // Ahora puedes acceder a la información de la ruta, como los puntos de inicio y finalización, la distancia, la duración, etc.
    // Por ejemplo:
    if let route = googleMapsResponse.routes.first {
        print("Distancia de la ruta: \(route.legs.first?.distance.text ?? "")")
        print("Duración de la ruta: \(route.legs.first?.duration.text ?? "")")
        print("Instrucciones de navegación:")
        for step in route.legs.first?.steps ?? [] {
            print("- \(step.htmlInstructions)")
        }
    }
} catch {
    print("Error al decodificar el JSON:", error)
}
