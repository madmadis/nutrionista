package ee.nutrionista.controller.feedback;

import ee.nutrionista.controller.feedback.dto.FeedbackDto;
import ee.nutrionista.service.FeedbackService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class FeedbackController {
    private final FeedbackService feedbackService;

    @PostMapping("/feedback")
    @Operation(summary = "Tagasiside")
    public void save(@RequestBody FeedbackDto dto) {
        feedbackService.save(dto);
    }
}
