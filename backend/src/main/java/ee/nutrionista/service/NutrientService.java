package ee.nutrionista.service;

import ee.nutrionista.controller.nutrient.dto.NutrientDto;
import ee.nutrionista.persistence.nutrient.NutrientMapper;
import ee.nutrionista.persistence.nutrient.NutrientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NutrientService {

    private final NutrientRepository nutrientRepository;
    private final NutrientMapper nutrientMapper;

    public List<NutrientDto> all() {
        return nutrientRepository.findAll()
                .stream()
                .map(nutrientMapper::toDto)
                .toList();
    }
}
