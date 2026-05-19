package ee.nutrionista.controller.nutrient;

import ee.nutrionista.controller.nutrient.dto.NutrientDto;
import ee.nutrionista.service.NutrientService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class NutrientController {
    private final NutrientService nutrientService;

    @GetMapping("/nutrients")
    @Operation(summary = "Kõikide ainete loetelu")
    public List<NutrientDto> all() {
        return nutrientService.findAllNutrients();
    }
}
