import re

def extract_data_from_lua(filename):
    with open(filename, 'r', encoding='utf-8') as f:  # Added encoding='utf-8'
        content = f.read()

    # Using regular expressions to extract the desired fields
    pattern = re.compile(r'\["name"\]\s*=\s*"([^"]+)",.*?\["race_id"\]\s*=\s*(\d+),.*?\["class_id"\]\s*=\s*(\d+),.*?\["level"\]\s*=\s*(\d+),.*?\["last_words"\]\s*=\s*"([^"]+)",', re.DOTALL)
    matches = pattern.findall(content)

    # Filtering only characters with non-empty last_words
    filtered_matches = [m for m in matches if m[4].strip()]

    return filtered_matches

def write_to_output(filename, data):
    with open(filename, 'w', encoding='utf-8') as f:  # Added encoding='utf-8'
        f.write("name,race_id,class_id,level,last_words\n")
        for entry in data:
            f.write(','.join(entry) + '\n')

def main():
    data = extract_data_from_lua('deathlog_alliance.txt')
    write_to_output('output.txt', data)

if __name__ == "__main__":
    main()
