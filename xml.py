from lxml import etree

# Load XML file, 'rb' = read binary
with open('./movies.xml', 'rb') as movies_file:
    # All elements from fileE
    tree = etree.parse(movies_file)

# Get root, movies element
root = tree.getroot()

# Loop movies
for movie in root.findall('movie'):
    # Get movies properties
    title = movie.find('title').text
    mc = movie.find('main_character').text
    author = movie.find('author').text
    year = movie.find('year').text
    
    # Print each movie details
    print('\033[34m-----\033[0m')
    print('\033[37mMovie details\033[0m')
    print('\033[34m-----\033[0m')
    print(f'\033[32mTitle:\033[0m          {title}')
    print(f'\033[32mMain character:\033[0m {mc}')
    print(f'\033[32mAuthor:\033[0m         {author}')
    print(f'\033[32mYear:\033[0m           {year}')
    print(f'\n')
