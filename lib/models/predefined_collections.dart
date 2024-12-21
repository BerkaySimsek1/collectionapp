final Map<String, List<Map<String, String>>> predefinedCollections = {
  "Plak": [
    {"name": "Sanatçı", "type": "TextField"},
    {"name": "Albüm Adı", "type": "TextField"},
    {
      "name": "Format",
      "type": "Dropdown",
      "options": "33'lük, 45'lik, 78'lik",
    },
  ],
  "Pul": [
    {"name": "Ülke", "type": "TextField"},
    {"name": "Yıl", "type": "NumberField"},
    {"name": "Değer", "type": "NumberField"},
  ],
  "Metal Para": [
    {"name": "Ülke", "type": "TextField"},
    {"name": "Tarih", "type": "DatePicker"},
    {
      "name": "Materyal",
      "type": "Dropdown",
      "options": "Altın,Gümüş,Bronz,Bakır"
    },
  ],
  "Kitap": [
    {"name": "Yazar", "type": "TextField"},
    {"name": "Başlık", "type": "TextField"},
    {"name": "Yayın Tarihi", "type": "DatePicker"},
  ],
};
