final Map<String, List<Map<String, String>>> predefinedCollections = {
  "Record": [
    {"name": "Artist", "type": "TextField"},
    {"name": "Album Title", "type": "TextField"},
    {"name": "Format", "type": "Dropdown", "options": "33 RPM,45 RPM,78 RPM"},
    {
      "name": "Genre",
      "type": "Dropdown",
      "options": "Rock,Pop,Jazz,Classical,Other"
    },
  ],
  "Stamp": [
    {"name": "Country", "type": "TextField"},
    {"name": "Year", "type": "NumberField"},
    {"name": "Value", "type": "NumberField"},
    {"name": "Theme", "type": "TextField"},
  ],
  "Coin": [
    {"name": "Country", "type": "TextField"},
    {"name": "Date", "type": "DatePicker"},
    {
      "name": "Material",
      "type": "Dropdown",
      "options": "Gold,Silver,Bronze,Copper"
    },
    {"name": "Denomination", "type": "NumberField"},
  ],
  "Book": [
    {"name": "Author", "type": "TextField"},
    {"name": "Title", "type": "TextField"},
    {"name": "Publish Date", "type": "DatePicker"},
    {
      "name": "Genre",
      "type": "Dropdown",
      "options": "Fiction,Non-fiction,Science,Fantasy,Other"
    },
  ],
  "Painting": [
    {"name": "Artist", "type": "TextField"},
    {"name": "Title", "type": "TextField"},
    {"name": "Year", "type": "NumberField"},
    {
      "name": "Medium",
      "type": "Dropdown",
      "options": "Oil,Acrylic,Watercolor,Pastel,Other"
    },
    {"name": "Dimensions", "type": "TextField"},
  ],
  "Comic Book": [
    {"name": "Publisher", "type": "TextField"},
    {"name": "Issue Number", "type": "NumberField"},
    {"name": "Release Date", "type": "DatePicker"},
    {
      "name": "Condition",
      "type": "Dropdown",
      "options": "Mint,Near Mint,Fine,Good,Poor"
    },
  ],
  "Vintage Posters": [
    {"name": "Title", "type": "TextField"},
    {"name": "Year", "type": "NumberField"},
    {
      "name": "Condition",
      "type": "Dropdown",
      "options": "Mint,Near Mint,Fine,Good,Poor"
    },
    {"name": "Size", "type": "TextField"},
  ],
};
