package ee.nutrionista.persistence.category;

import ee.nutrionista.controller.category.dto.CategoryDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CategoryMapper {
    @Mapping(source = "id", target = "categoryId")
    CategoryDto toDto(Category category);
}
