import csv

# Define the mappings for race_id and class_id
race_mapping = {
    "1": "Human",
    "3": "Dwarf",
    "4": "Night Elf",
    "7": "Gnome"
}

class_mapping = {
    "1": "Warrior",
    "2": "Paladin",
    "3": "Hunter",
    "4": "Rogue",
    "5": "Priest",
    "8": "Mage",
    "11": "Druid"
}

# Read existing character_ids from alliance_master.txt
existing_character_ids = set()
with open("alliance_master.txt", "r", encoding='utf-8') as master_file:
    reader = csv.reader(master_file)
    for row in reader:
        character_id = row[0]
        existing_character_ids.add(character_id)

# Process the data from output_alliance.txt and write to alliance_master.txt
with open("output_alliance.txt", "r", encoding='utf-8') as input_file, open("alliance_master.txt", "a",
                                                                            encoding='utf-8',
                                                                            newline='') as master_file:
    reader = csv.reader(input_file)
    writer = csv.writer(master_file)

    for row in reader:
        character_id, name, race_id, class_id, level, last_words = row

        # Check if character_id already exists
        if character_id not in existing_character_ids:
            # Transform race_id and class_id
            race = race_mapping.get(race_id, race_id)  # if not found, keep the original id
            char_class = class_mapping.get(class_id, class_id)  # if not found, keep the original id

            # Write to alliance_master.txt
            writer.writerow([character_id, name, race, char_class, level, last_words])
