package ee.nutrionista.service;

import ee.nutrionista.controller.category.dto.CategoryDto;
import ee.nutrionista.persistence.category.Category;
import ee.nutrionista.persistence.category.CategoryMapper;
import ee.nutrionista.persistence.category.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final CategoryMapper categoryMapper;

    public List<CategoryDto> findAllCategories() {
        List<Category> categories = categoryRepository.findAll();
        return categoryMapper.toCategoryDtos(categories);
    }
}