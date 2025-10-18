class ExtinctAnimal {
  final String name;
  final String imagePath;
  final String extinctionRate;
  final String causeOfExtinction;
  final String history;

  ExtinctAnimal({
    required this.name,
    required this.imagePath,
    required this.extinctionRate,
    required this.causeOfExtinction,
    required this.history,
  });
}

// Dummy data for the carousel - Add your images to assets/images/
final List<ExtinctAnimal> extinctAnimalsList = [
  ExtinctAnimal(
    name: 'Formosan Clouded Leopard',
    imagePath: 'assets/images/leopard.jpg', // You need to add this image
    extinctionRate: 'Officially Extinct (2013)',
    causeOfExtinction: 'Habitat destruction due to logging and poaching for its valuable skin.',
    history: 'A subspecies of the clouded leopard endemic to Taiwan, it was a mysterious and revered predator of the island\'s forests. The last official sighting was in 1983.',
  ),
  ExtinctAnimal(
    name: 'Taiwan Sika Deer',
    imagePath: 'assets/images/sika_deer.jpg', // You need to add this image
    extinctionRate: 'Extinct in the Wild (1969)',
    causeOfExtinction: 'Over-hunting for its hide and antlers, and habitat loss to agriculture.',
    history: 'Once roamed the lowlands in vast herds. A captive breeding program has successfully reintroduced populations in Kenting National Park.',
  ),
  // Add 5 more animals with their respective images here
];