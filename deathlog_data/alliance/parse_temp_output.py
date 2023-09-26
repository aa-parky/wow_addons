def extract_details_from_temp(file_path):
    players = []
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    current_player = {}
    for line in lines:
        if line.startswith("Player ID"):
            current_player["Player ID"] = line.split(":")[1].strip()
        elif line.startswith("name"):
            current_player["name"] = line.split(":")[1].strip()
        elif line.startswith("race_id"):
            current_player["race_id"] = line.split(":")[1].strip()
        elif line.startswith("class_id"):
            current_player["class_id"] = line.split(":")[1].strip()
        elif line.startswith("level"):
            current_player["level"] = line.split(":")[1].strip()
        elif line.startswith("last_words"):
            current_player["last_words"] = line.split(":")[1].strip()
        elif line.startswith("-"*40):
            players.append(current_player)
            current_player = {}
    return players

def extract_existing_ids(file_path):
    existing_ids = set()
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        for line in lines:
            if line.startswith("Player ID"):
                existing_ids.add(line.split(":")[1].strip())
    except FileNotFoundError:
        pass
    return existing_ids

def append_new_players_to_master(new_players, existing_ids, file_path):
    with open(file_path, 'a', encoding='utf-8') as file:
        for player in new_players:
            if player["Player ID"] not in existing_ids:
                file.write(f"Player ID: {player['Player ID']}\n")
                file.write(f"name: {player['name']}\n")
                file.write(f"race_id: {player['race_id']}\n")
                file.write(f"class_id: {player['class_id']}\n")
                file.write(f"level: {player['level']}\n")
                file.write(f"last_words: {player['last_words']}\n")
                file.write("-"*40 + "\n")

new_players = extract_details_from_temp('temp_output_alliance.txt')
existing_ids = extract_existing_ids('master_alliance.txt')
append_new_players_to_master(new_players, existing_ids, 'master_alliance.txt')
