package ee.nutrionista.controller.nutrient.dto;

import ee.nutrionista.persistence.category.Category;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor

public class NutrientDto {
    private Integer id;
    private String name;
    private String description;
    private Category category;
    private BigDecimal price;
    private Integer stock_quantity;
}
