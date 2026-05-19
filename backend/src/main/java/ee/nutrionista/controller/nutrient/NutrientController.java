package ee.nutrionista.controller.nutrient;

import ee.nutrionista.controller.nutrient.dto.NutrientDto;
import ee.nutrionista.service.NutrientService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class NutrientController {
    private final NutrientService nutrientService;

    @GetMapping("/nutrients")
    @Operation(summary = "Kõikide ainete loetelu")
    public List<NutrientDto> findNutrients(@RequestParam Integer categoryId) {
        return nutrientService.findNutrients(categoryId);
    }

    @GetMapping("/nutrients/{id}")
    @Operation(summary = "Ühe aine andmed")
    public NutrientDto findNutrientById(@PathVariable Integer id) {
        return nutrientService.findNutrientById(id);
    }
}
