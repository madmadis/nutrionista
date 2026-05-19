package ee.nutrionista.persistence.nutrient;

import org.springframework.data.jpa.repository.JpaRepository;

// Provides CRUD for nutrient_image rows. Inherits the following from JpaRepository / CrudRepository:
//   findById(Integer id)  → Optional<NutrientImage>  (used by NutrientImageService.find)
//   findAll()             → List<NutrientImage>
//   save(NutrientImage)   → inserts or updates
//   deleteById(Integer id)
//   existsById(Integer id), count(), and ~10 more.
// No custom queries needed for the home page's image endpoint.
public interface NutrientImageRepository extends JpaRepository<NutrientImage, Integer> {
}
