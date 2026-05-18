package ee.nutrionista.feedback;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/feedback")
public class FeedbackController {

    private final FeedbackRepository feedbackRepository;

    public FeedbackController(FeedbackRepository feedbackRepository) {
        this.feedbackRepository = feedbackRepository;
    }

    @PostMapping
    public ResponseEntity<Void> submit(@Valid @RequestBody FeedbackDto dto) {
        Feedback feedback = new Feedback();
        feedback.setName(dto.getName());
        feedback.setEmail(dto.getEmail());
        feedback.setMessage(dto.getMessage());
        feedbackRepository.save(feedback);
        return ResponseEntity.ok().build();
    }
}
