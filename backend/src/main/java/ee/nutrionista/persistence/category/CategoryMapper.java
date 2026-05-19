package ee.nutrionista.persistence.category;

import ee.nutrionista.controller.category.dto.CategoryDto;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface CategoryMapper {
    CategoryDto toDto(Category category);
}
