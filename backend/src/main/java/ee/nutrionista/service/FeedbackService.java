package ee.nutrionista.service;

import ee.nutrionista.controller.feedback.dto.FeedbackDto;
import ee.nutrionista.persistence.feedback.FeedbackMapper;
import ee.nutrionista.persistence.feedback.FeedbackRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final FeedbackMapper feedbackMapper;

    public void save(FeedbackDto dto) {
        feedbackRepository.save(feedbackMapper.toEntity(dto));
    }

}
