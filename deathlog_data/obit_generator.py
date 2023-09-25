import csv
import random
import os

# Ensure the output directory exists, if not create it
if not os.path.exists('alliance_obits'):
    os.makedirs('alliance_obits')

# 1. Read alliance_master.txt
characters = []
with open('alliance_master.txt', 'r', encoding='utf-8') as file:
    reader = csv.reader(file)
    for row in reader:
        character = {
            "character_id": row[0],
            "name": row[1],
            "race_id": row[2],
            "class_id": row[3],
            "level": row[4],
            "last_words": row[5]
        }
        characters.append(character)

# 2. Read obituaries_lines_.txt
obituaries = []
with open('obituaries_lines_.txt', 'r', encoding='utf-8') as file:
    obituaries = [line for line in file if line.strip()]  # excluding empty lines

# 3. Process characters and obituaries
for character in characters:
    try:
        chosen_obituary = random.choice(obituaries)
        obituary_text = chosen_obituary.format(
            name=character['name'],
            race_id=character['race_id'],
            class_id=character['class_id'],
            level=character['level'],
            last_words=character['last_words']
        )

        # Check if the formatted text is still having any placeholders (in curly braces)
        if "{" in obituary_text or "}" in obituary_text:
            print(
                f"Warning: Placeholder mismatch for character {character['character_id']}. Using obituary: {chosen_obituary}")

        # Write to the respective file in alliance_obits directory
        with open(os.path.join('alliance_obits', character['character_id'] + '.txt'), 'w',
                  encoding='utf-8') as out_file:
            out_file.write(obituary_text)

    except Exception as e:
        print(f"Error processing character {character['character_id']}: {e}")

print("Obituaries generated successfully!")
