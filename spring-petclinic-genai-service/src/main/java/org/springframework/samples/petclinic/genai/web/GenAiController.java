package org.springframework.samples.petclinic.genai.web;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/genai")
public class GenAiController {

	@GetMapping("/status")
	public Map<String, String> status() {
		return Map.of(
				"service", "genai-service",
				"status", "UP",
				"description", "Spring PetClinic Generative AI microservice");
	}

}
