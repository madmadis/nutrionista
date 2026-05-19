package ee.nutrionista.controller.category;

import ee.nutrionista.controller.category.dto.CategoryDto;
import ee.nutrionista.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class CategoryController {
    private final CategoryService categoryService;

    @GetMapping("/categories")
    @Operation(summary = "Kategooriad")
    public List<CategoryDto> findAllCategories() {
        return categoryService.findAllCategories();
    }
}
