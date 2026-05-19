package ee.nutrionista.service;

import ee.nutrionista.controller.nutrient.dto.NutrientDto;
import ee.nutrionista.persistence.nutrient.Nutrient;
import ee.nutrionista.persistence.nutrient.NutrientMapper;
import ee.nutrionista.persistence.nutrient.NutrientRepository;
import ee.nutrionista.infrastructure.exception.NutrientNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NutrientService {

    private final NutrientRepository nutrientRepository;
    private final NutrientMapper nutrientMapper;

    public List<NutrientDto> findNutrients(Integer categoryId) {
        List<Nutrient> nutrients = nutrientRepository.findNutrientsBy(categoryId);
        return nutrientMapper.toNutrientDtos(nutrients);
    }
    public NutrientDto findNutrientById(Integer id) {
        Nutrient nutrient = nutrientRepository.findById(id)
                .orElseThrow(NutrientNotFoundException::new);
        return nutrientMapper.toNutrientDto(nutrient);
    }
}
