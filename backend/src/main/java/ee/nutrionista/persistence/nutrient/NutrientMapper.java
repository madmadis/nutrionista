package ee.nutrionista.persistence.nutrient;

import ee.nutrionista.controller.nutrient.dto.NutrientDto;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NutrientMapper {
    NutrientDto toDto(Nutrient nutrient);
}