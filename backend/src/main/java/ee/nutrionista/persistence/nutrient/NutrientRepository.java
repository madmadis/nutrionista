package ee.nutrionista.persistence.nutrient;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NutrientRepository extends JpaRepository<Nutrient, Integer> {


    @Query("select n from Nutrient n where (:categoryId = 0 or n.category.id = :categoryId) order by n.category.name, n.name")
    List<Nutrient> findNutrientsBy(Integer categoryId);
}
