package ee.nutrionista.service;

import ee.nutrionista.persistence.nutrient.NutrientImage;
import ee.nutrionista.persistence.nutrient.NutrientImageRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

// @Service marks this as a Spring-managed bean; Spring instantiates it once at startup and injects it where requested.
// @RequiredArgsConstructor (Lombok) generates a constructor for every `final` field below, so Spring auto-wires
// NutrientImageRepository via constructor injection — we don't write the constructor ourselves.
@Service
@RequiredArgsConstructor
public class NutrientImageService {

    private final NutrientImageRepository nutrientImageRepository;

    // Find one image row by its id. Throws EntityNotFoundException if not found —
    // RestExceptionHandler.handleEntityNotFound catches it and returns a 404 with the message below.
    public NutrientImage find(Integer id) {
        Optional<NutrientImage> maybeImage = nutrientImageRepository.findById(id);

        if (maybeImage.isPresent()) {
            return maybeImage.get();
        } else {
            throw new EntityNotFoundException("Pilti ei leitud");
        }
    }
}