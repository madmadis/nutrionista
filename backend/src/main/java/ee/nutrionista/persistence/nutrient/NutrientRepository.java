package ee.nutrionista.persistence.nutrient;

import org.springframework.data.jpa.repository.JpaRepository;

public interface NutrientRepository extends JpaRepository<Nutrient, Integer> {

}
