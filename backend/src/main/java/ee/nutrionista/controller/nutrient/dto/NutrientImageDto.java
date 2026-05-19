package ee.nutrionista.controller.nutrient.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// Response shape for GET /api/nutrient-images/{id}. Jackson serializes this to JSON like:
//   { "id": 1, "imageUrl": "https://placehold.co/400x300" }
// @Data (Lombok) generates getters, setters, equals, hashCode, and toString for every field below.
// @NoArgsConstructor generates `new NutrientImageDto()` — Jackson uses it when deserializing.
// @AllArgsConstructor generates `new NutrientImageDto(id, imageUrl)` — handy in tests and one-liners.
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NutrientImageDto {
    private Integer nutrientImageId;
    private String imageUrl;
}
