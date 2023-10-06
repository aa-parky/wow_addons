import re
from slpp import slpp as lua

def parse_lua_to_python(lua_string):
    lua_string = lua_string.replace("nil", "None")
    return lua.decode(lua_string)

def is_valid_lua_string(s):
    try:
        lua.decode("{" + s + "}")
        return True
    except:
        return False

def extract_individual_players(content):
    pattern = re.compile(r'\["(.*?)"\]\s*=\s*\{(.*?)\}', re.DOTALL)
    return pattern.findall(content)

def process_player_data(player_id, player_data, special_char_pattern):
    if 'last_words' in player_data and special_char_pattern.search(player_data['last_words']):
        print(f"Skipping player due to special character in 'last_words': {player_id}")
    else:
        return player_data

def extract_player_data(data, class_mappings, race_mappings):
    results = []
    for player_id, info in data.items():
        last_words = info.get("last_words", "").strip()
        if last_words:
            info["class_id"] = class_mappings.get(info["class_id"], info["class_id"])
            info["race_id"] = race_mappings.get(info["race_id"], info["race_id"])
            player_data = [f"Player ID: {player_id}"]
            player_data.extend([f"{key}: {value}" for key, value in info.items()])
            results.append("\n".join(player_data) + "\n" + "-" * 40)
    return results

class_mappings = {
    1: "Warrior",
    2: "Paladin",
    3: "Hunter",
    4: "Rogue",
    5: "Priest",
    7: "Shaman",
    8: "Mage",
    9: "Warlock",
    11: "Druid",
}

race_mappings = {
    1: "Human",
    2: "Orc",
    3: "Dwarf",
    4: "Night Elf",
    5: "Undead",
    6: "Tauren",
    7: "Gnome",
    8: "Troll",
}

try:
    with open('Deathlog.lua', 'r', encoding='utf-8') as file:
        content = file.read()
        print("File content:", content[:100])
        all_players_data = extract_individual_players(content)
        complete_data = {}
        special_char_pattern = re.compile(r'[!@#$%^&*(){}\[\];:<>,.?~\\/-]+')

        for player_id, player_data_str in all_players_data:
            try:
                if not is_valid_lua_string(player_data_str):
                    print(f"Invalid Lua structure for player/realm: {player_id}")
                    continue  # Skip this player/realm

                player_data = parse_lua_to_python("{" + player_data_str + "}")

                # Check for nested structure like "legacy"
                if isinstance(player_data, dict) and any(isinstance(val, dict) for val in player_data.values()):
                    for nested_player_id, nested_player_data in player_data.items():
                        nested_processed_data = process_player_data(nested_player_id, nested_player_data, special_char_pattern)
                        if nested_processed_data:
                            complete_data[nested_player_id] = nested_processed_data
                else:
                    processed_data = process_player_data(player_id, player_data, special_char_pattern)
                    if processed_data:
                        complete_data[player_id] = processed_data
            except Exception as e:
                print(f"Error while processing player or realm: {player_id}")
                print(player_data_str)
                raise e

        player_data_list = extract_player_data(complete_data, class_mappings, race_mappings)
        print(f"Number of Players Extracted: {len(player_data_list)}")

        with open('temp_output_alliance.txt', 'w', encoding='utf-8') as out_file:
            for entry in player_data_list:
                out_file.write(entry + "\n")

        print("Finished writing to the file.")
except Exception as e:
    print("Error occurred:", e)
