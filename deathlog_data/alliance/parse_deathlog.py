import re
from slpp import slpp as lua

def parse_lua_to_python(lua_string):
    lua_string = lua_string.replace("nil", "None")
    return lua.decode(lua_string)

def extract_player_data(data):
    server_data = data.get("Stitches", {})
    results = []
    for player_id, info in server_data.items():
        last_words = info.get("last_words", "").strip()
        if last_words:
            # Prepend the unique player name and then add all data for the player
            player_data = [f"Player ID: {player_id}"]
            player_data.extend([f"{key}: {value}" for key, value in info.items()])
            results.append("\n".join(player_data) + "\n" + "-"*40)  # Add separator
    return results

def extract_lua_table(content, table_name):
    match = re.search(fr"{table_name} = (\{{)", content)
    if not match:
        return None
    start_idx = match.start(1)
    end_idx = start_idx + 1
    balance = 1
    while balance != 0 and end_idx < len(content):
        if content[end_idx] == '{':
            balance += 1
        elif content[end_idx] == '}':
            balance -= 1
        end_idx += 1
    if balance == 0:
        return content[start_idx:end_idx]
    else:
        return None

with open('Deathlog.lua', 'r', encoding='utf-8') as file:
    content = file.read()
    deathlog_data_str = extract_lua_table(content, "deathlog_data")
    if deathlog_data_str:
        deathlog_data = parse_lua_to_python(deathlog_data_str)
        player_data_list = extract_player_data(deathlog_data)
        with open('temp_output_alliance.txt', 'w', encoding='utf-8') as out_file:
            for entry in player_data_list:
                out_file.write(entry + "\n")
