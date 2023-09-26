import os
import random


def read_players_data(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read().split("----------------------------------------")
        players = []

        for player_data in content:
            lines = player_data.strip().split("\n")
            player = {}
            for line in lines:
                if not line.strip():
                    continue

                parts = line.split(": ")
                if len(parts) == 2:
                    key, value = parts
                    player[key] = value
                elif len(parts) == 1:
                    key = parts[0]
                    player[key] = None  # or 'Unknown' or any default value
                else:
                    print(f"Error processing line: '{line}'")

            if player:
                players.append(player)

        return players



def generate_obituaries(template_path, players):
    with open(template_path, 'r', encoding='utf-8') as file:
        templates = file.read().strip().split("\n\n")

    obituaries = []

    for player in players:
        template = random.choice(templates)  # Choose a random template for each player
        obituary = template.format(
            name=player.get('name', 'Unknown'),
            race_id=player.get('race_id', 'Unknown'),
            class_id=player.get('class_id', 'Unknown'),
            level=player.get('level', 'Unknown'),
            last_words=player.get('last_words', 'No last words')
        )
        obituaries.append(obituary)

    return obituaries


def write_obituaries_to_files(obituaries, players):
    directory = "alliance_obits"
    if not os.path.exists(directory):
        os.makedirs(directory)

    for obit, player in zip(obituaries, players):
        filename = os.path.join(directory, f"{player['Player ID']}.txt")

        if not os.path.exists(filename):
            with open(filename, 'w', encoding='utf-8') as file:
                file.write(obit)


if __name__ == "__main__":
    players_data_path = "alliance/master_alliance.txt"
    obituaries_template_path = "data/obituaries_lines.txt"

    players = read_players_data(players_data_path)
    obituaries = generate_obituaries(obituaries_template_path, players)
    write_obituaries_to_files(obituaries, players)
