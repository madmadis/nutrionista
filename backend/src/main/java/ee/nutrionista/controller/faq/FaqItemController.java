package ee.nutrionista.controller.faq;

import ee.nutrionista.controller.faq.dto.FaqItemDto;
import ee.nutrionista.service.FaqItemService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class FaqItemController {
    private final FaqItemService faqItemService;

    @GetMapping("/faq")
    @Operation(summary = "Korduma kippuvad küsimused")
    public List<FaqItemDto> all() {
        return faqItemService.findAllFaq();
    }
}
