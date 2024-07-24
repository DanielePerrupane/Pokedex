#  Guida

Campi da estrarre: 

    https://pokeapi.co/api/v2/pokemon/\(pokemon.id)/ {
        
        - images 
        - types
        
    }
    https://pokeapi.co/api/v2/pokemon-species/\(pokemon.id) {
        - name
        - flavor_text 
        
    }
        



2. images {

                "sprites": {
        
                    "other": {
            
                        "official-artwork": {
                            "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png",
        
                        }

                    }
                }
}
        

3. types {

                "types": [
                    {
                        "slot": 1,
                        "type": {
                            "name": "grass",
                            "url": "https://pokeapi.co/api/v2/type/12/"
                        }
                    },
                    {
                        "slot": 2,
                        "type": {
                            "name": "poison",
                            "url": "https://pokeapi.co/api/v2/type/4/"
                        }
                    }
                ],
                
}


4. flavor_text {

            https://pokeapi.co/api/v2/pokemon-species/\(pokemon.id)/
            
            
            "flavor_text_entries": [
                {
                    "flavor_text": "When the bulb on\nits back grows\nlarge, it appears\fto lose the\nability to stand\non its hind legs.",
                    "language": {
                        "name": "en",
                        "url": "https://pokeapi.co/api/v2/language/9/"
                    },
                    "version": {
                        "name": "red",
                        "url": "https://pokeapi.co/api/v2/version/1/"
                    }
                },




}
