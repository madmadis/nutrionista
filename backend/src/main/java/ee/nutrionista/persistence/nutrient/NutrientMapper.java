package ee.nutrionista.persistence.nutrient;

import ee.nutrionista.controller.nutrient.dto.NutrientDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface NutrientMapper {


    @Mapping(source = "id", target = "nutrientId")
    @Mapping(source = "name", target = "name")
    @Mapping(source = "description", target = "description")
    @Mapping(source = "category.name", target = "categoryName")
    @Mapping(source = "price", target = "price")
    @Mapping(source = "stockQuantity", target = "stockQuantity")
    NutrientDto toNutrientDto(Nutrient nutrient);

    List<NutrientDto> toNutrientDtos(List<Nutrient> nutrients);

}