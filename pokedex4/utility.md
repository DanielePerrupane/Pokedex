#  <#Title#>

LINK pokemon : https://pokeapi.co/api/v2/pokemon/\(pokemon.id)/

da cui estrarre :
- types (direttamente) :

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

- flavorText (indirettamente) da :

                    "name": "bulbasaur",
              "order": 1,
              "past_abilities": [],
              "past_types": [],
              "species": {
                "name": "bulbasaur",
                "url": "https://pokeapi.co/api/v2/pokemon-species/1/" ->
    
                                            description:
                                lavor_text_entries": [
                                    {
                                      "flavor_text": "Spits fire that\nis hot enough to\nmelt boulders.\fKnown to cause\nforest fires\nunintentionally.",
                                      "language": {
                                        "name": "en",
                                        "url": "https://pokeapi.co/api/v2/language/9/"
                                      },


