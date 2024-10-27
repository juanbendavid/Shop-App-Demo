// funcion para retornar un int en String con punto como separador de miles
String formatNumber(int value) {
  return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
}
