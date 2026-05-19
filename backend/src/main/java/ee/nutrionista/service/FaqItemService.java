package ee.nutrionista.service;

import ee.nutrionista.controller.faq.dto.FaqItemDto;
import ee.nutrionista.persistence.faq.FaqItemMapper;
import ee.nutrionista.persistence.faq.FaqItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FaqItemService {

    private final FaqItemRepository faqItemRepository;
    private final FaqItemMapper faqItemMapper;

    public List<FaqItemDto> findAllFaq() {
        return faqItemRepository.findAll()
                .stream()
                .map(faqItemMapper::toDto)
                .toList();
    }
}
